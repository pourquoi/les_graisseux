<?php

namespace App\Security\Voter;

use App\Entity\ChatRoom;
use App\Entity\User;
use Symfony\Component\Security\Core\Authentication\Token\TokenInterface;
use Symfony\Component\Security\Core\Authorization\Voter\Voter;
use Symfony\Component\Security\Core\Security;

class ChatRoomVoter extends Voter
{
    private $security = null;

    public function __construct(Security $security)
    {
        $this->security = $security;
    }

    protected function supports($attribute, $subject): bool
    {
        $supportsAttribute = in_array($attribute, ['SUBSCRIBE']);
        $supportsSubject = $subject instanceof ChatRoom;

        return $supportsAttribute && $supportsSubject;
    }

    /**
     * @param string $attribute
     * @param ChatRoom $chat
     * @param TokenInterface $token
     * @return bool|void
     */
    protected function voteOnAttribute(string $attribute, $chat, TokenInterface $token)
    {
        /** @var User $current_user */
        $current_user = $this->security->getUser();

        if (!$current_user) return false;

        switch($attribute) {
            case 'SUBSCRIBE': return true;
        }
    }
}