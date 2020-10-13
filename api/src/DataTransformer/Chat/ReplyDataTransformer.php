<?php

namespace App\DataTransformer\Chat;

use ApiPlatform\Core\DataTransformer\DataTransformerInterface;
use ApiPlatform\Core\Validator\ValidatorInterface;
use App\Dto\Chat\CreateChat;
use App\Dto\Chat\Reply;
use App\Entity\ChatMessage;
use App\Entity\ChatRoom;
use App\Entity\ChatUser;
use App\Repository\ChatRoomRepository;
use App\Repository\ChatUserRepository;
use App\Repository\UserRepository;
use Doctrine\ORM\NonUniqueResultException;
use Symfony\Component\Security\Core\Security;

class ReplyDataTransformer implements DataTransformerInterface
{
    private $security;
    private $validator;
    private $userRepository;
    private $chatUserRepository;
    private $chatRoomRepository;

    public function __construct(Security $security, ValidatorInterface $validator, UserRepository $userRepository, ChatUserRepository $chatUserRepository, ChatRoomRepository $chatRoomRepository)
    {
        $this->security = $security;
        $this->validator = $validator;
        $this->userRepository = $userRepository;
        $this->chatUserRepository = $chatUserRepository;
        $this->chatRoomRepository = $chatRoomRepository;
    }

    /**
     * @var Reply $data
     * @throws NonUniqueResultException
     * @return ChatMessage
     */
    public function transform($data, string $to, array $context = [])
    {
        $this->validator->validate($data);

        /** @var ChatRoom $room */
        $room = $this->chatRoomRepository->findOneByUuid($data->room);

        if (!$room) {
            throw new \InvalidArgumentException(sprintf('Error posting chat reply: room %s not found', $data->room));
        }

        if (null !== $data->user && ($this->security->isGranted('ROLE_ADMIN_BO') || null === $this->security->getUser())) {
            $fromUser = $this->userRepository->find($data->user);

            if (null === $fromUser) {
                throw new \InvalidArgumentException(sprintf('Error creating chat: user %d not found', $data->user));
            }
        } else {
            $fromUser = $this->security->getUser();
        }

        $fromChatUser = $this->chatUserRepository->findOneByRoomAndUser($room, $fromUser);

        if (null === $fromChatUser) {
            $fromChatUser = new ChatUser();
            $fromChatUser->setUser($fromUser);
            $room->addUser($fromChatUser);
        }


        $message = new ChatMessage();
        $message->setUser($fromChatUser);
        $message->setMessage($data->message);
        $room->addMessage($message);

        return $message;
    }

    public function supportsTransformation($data, string $to, array $context = []): bool
    {
        if ($data instanceof ChatMessage) {
            return false;
        }

        return $to === ChatMessage::class && null !== ($context['input']['class'] ?? null);
    }

}