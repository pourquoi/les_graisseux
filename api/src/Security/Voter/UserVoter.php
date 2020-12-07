<?php

namespace App\Security\Voter;

use App\Entity\User;
use Symfony\Component\Security\Core\Authentication\Token\TokenInterface;
use Symfony\Component\Security\Core\Authorization\Voter\Voter;
use Symfony\Component\Security\Core\Security;

class UserVoter extends Voter
{
    private $security = null;

    public function __construct(Security $security)
    {
        $this->security = $security;
    }

    protected function supports($attribute, $subject): bool
    {
        $supportsAttribute = in_array($attribute, ['SUBSCRIBE', 'READ_PRIVATE', 'EDIT_USER', 'DELETE_USER']);
        $supportsSubject = $subject instanceof User;

        return $supportsAttribute && $supportsSubject;
    }

    /**
     * @param string $attribute
     * @param User $user
     * @param TokenInterface $token
     * @return bool|void
     */
    protected function voteOnAttribute(string $attribute, $user, TokenInterface $token)
    {
        /** @var User $current_user */
        $current_user = $this->security->getUser();

        if (!$current_user) return false;

        switch($attribute) {
            case 'SUBSCRIBE':
                return $current_user->getId() == $user->getId();

            case 'READ_PRIVATE':
            case 'EDIT_USER':
            case 'DELETE_USER':
                if ($current_user->isAdmin())
                    return true;

                return $current_user->getId() == $user->getId();
        }
    }


}
