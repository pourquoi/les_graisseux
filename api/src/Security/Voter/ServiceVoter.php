<?php

namespace App\Security\Voter;

use App\Entity\ServiceTree;
use App\Entity\User;
use Symfony\Component\Security\Core\Authentication\Token\TokenInterface;
use Symfony\Component\Security\Core\Authorization\Voter\Voter;
use Symfony\Component\Security\Core\Security;

class ServiceVoter extends Voter
{
    private $security = null;

    public function __construct(Security $security)
    {
        $this->security = $security;
    }

    protected function supports(string $attribute, $subject)
    {
        $supportsAttribute = in_array($attribute, ['CREATE_SERVICE', 'EDIT_SERVICE']);
        $supportsSubject = $subject instanceof ServiceTree;

        return $supportsAttribute && $supportsSubject;
    }

    /**
     * @param string $attribute
     * @param ServiceTree $service
     * @param TokenInterface $token
     * @return bool|void
     */
    protected function voteOnAttribute(string $attribute, $service, TokenInterface $token)
    {
        /** @var User $current_user */
        $current_user = $this->security->getUser();

        if (!$current_user instanceof User) {
            return false;
        }

        switch($attribute) {
            case 'CREATE_SERVICE':
            case 'EDIT_SERVICE':
                return $current_user->isAdmin();
        }
    }

}