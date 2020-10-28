<?php

namespace App\DataTransformer\Chat;

use ApiPlatform\Core\DataTransformer\DataTransformerInterface;
use ApiPlatform\Core\Validator\ValidatorInterface;
use App\Dto\Chat\CreateChat;
use App\Entity\ChatMessage;
use App\Entity\ChatRoom;
use App\Entity\ChatUser;
use App\Repository\ChatUserRepository;
use App\Repository\UserRepository;
use Doctrine\ORM\NonUniqueResultException;
use Symfony\Component\Security\Core\Security;

class CreateChatDataTransformer implements DataTransformerInterface
{
    private $security;
    private $validator;
    private $userRepository;
    private $chatUserRepository;

    public function __construct(Security $security, ValidatorInterface $validator, UserRepository $userRepository, ChatUserRepository $chatUserRepository)
    {
        $this->security = $security;
        $this->validator = $validator;
        $this->userRepository = $userRepository;
        $this->chatUserRepository = $chatUserRepository;
    }

    /**
     * @var CreateChat $data
     * @throws NonUniqueResultException
     * @return ChatRoom
     */
    public function transform($data, string $to, array $context = [])
    {
        /** @var ChatRoom $room */
        $room = new ChatRoom();

        $this->validator->validate($data);

        if (null !== $data->from && $data->from->getId() && ($this->security->isGranted('ROLE_ADMIN_BO') || null === $this->security->getUser())) {
            $fromUser = $data->from;
        } else {
            $fromUser = $this->security->getUser();
        }

        $fromChatUser = new ChatUser();
        $fromChatUser->setUser($fromUser);

        $toChatUser = null;
        if ($data->to && $data->to->getId()) {
            $toUser = $data->to;

            $toChatUser = new ChatUser();
            $toChatUser->setUser($toUser);
        }

        // @todo reuse existing room with only those 2 users

        $room->addUser($fromChatUser);
        if (null !== $toChatUser)
            $room->addUser($toChatUser);

        if ($data->message !== null) {
            $message = new ChatMessage();
            $message->setMessage($data->message);
            $message->setUser($fromChatUser);
            $room->addMessage($message);
        }

        return $room;
    }

    public function supportsTransformation($data, string $to, array $context = []): bool
    {
        if ($data instanceof ChatRoom) {
            return false;
        }

        return $to === ChatRoom::class && null !== ($context['input']['class'] ?? null);
    }

}