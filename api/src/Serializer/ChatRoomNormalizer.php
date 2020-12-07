<?php

namespace App\Serializer;

use App\Entity\ChatRoom;
use App\Entity\User;
use Symfony\Component\Security\Core\Exception\AuthenticationCredentialsNotFoundException;
use Symfony\Component\Security\Core\Security;
use Symfony\Component\Serializer\Normalizer\ContextAwareNormalizerInterface;
use Symfony\Component\Serializer\Normalizer\NormalizerAwareInterface;
use Symfony\Component\Serializer\Normalizer\NormalizerAwareTrait;
use Symfony\Contracts\Translation\TranslatorInterface;

class ChatRoomNormalizer implements ContextAwareNormalizerInterface, NormalizerAwareInterface
{
    use NormalizerAwareTrait;
    private const ALREADY_CALLED = 'CHAT_ROOM_NORMALIZER_ALREADY_CALLED';
    private $security;
    private $translator;

    public function __construct(Security $security, TranslatorInterface $translator)
    {
        $this->security = $security;
        $this->translator = $translator;
    }

    public function supportsNormalization($data, string $format = null, array $context = [])
    {
        if (isset($context[self::ALREADY_CALLED])) {
            return false;
        }

        return $data instanceof ChatRoom;
    }

    /**
     * @param ChatRoom $object
     * @param string|null $format
     * @param array $context
     * @return array|null
     * @throws
     */
    public function normalize($object, string $format = null, array $context = [])
    {
        $context[self::ALREADY_CALLED] = true;

        $data = $this->normalizer->normalize($object, $format, $context);

        $user = null;
        try {
            $user = $this->security->getUser();
        } catch (AuthenticationCredentialsNotFoundException $e) {}

        if ($object->getJob()) {
            $data['title'] = $object->getJob()->getTitle();
        } else if ($object->getApplication()) {
            $data['title'] = $object->getApplication()->getJob()->getTitle();
        } else if ($object->isPrivate()) {
            $interlocutor = $object->getFirstInterlocutor($user);
            if ($interlocutor) {
                $data['title'] = $this->translator->trans('resource.chat_room.conversation_with', ['%username%'=>$interlocutor->getUser()->getUsername()]);
            }
        } else {
            $data['title'] = $this->translator->trans('resource.chat_room.public_chat', ['%id%'=>substr($object->getUuid()->toString(), -5)]);
        }

        return $data;
    }
}