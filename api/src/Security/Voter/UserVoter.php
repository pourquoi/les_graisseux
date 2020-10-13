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
        $supportsAttribute = in_array($attribute, ['EDIT_USER', 'DELETE_USER']);
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

        switch($attribute) {
            case 'EDIT_USER':
            case 'DELETE_USER':
                return $current_user->isAdmin() || $current_user->getId() == $user->getId();
        }
    }


}
