<?php

namespace App\Security\Voter;

use App\Entity\JobApplication;
use App\Entity\User;
use Symfony\Component\Security\Core\Authentication\Token\TokenInterface;
use Symfony\Component\Security\Core\Authorization\Voter\Voter;
use Symfony\Component\Security\Core\Security;

class ApplicationVoter extends Voter
{
    private $security = null;

    public function __construct(Security $security)
    {
        $this->security = $security;
    }

    protected function supports(string $attribute, $subject)
    {
        $supportsAttribute = in_array($attribute, ['READ_APPLICATION', 'CREATE_APPLICATION']);
        $supportsSubject = $subject instanceof JobApplication;

        return $supportsAttribute && $supportsSubject;
    }

    /**
     * @param string $attribute
     * @param JobApplication $application
     * @param TokenInterface $token
     * @return bool
     */
    protected function voteOnAttribute(string $attribute, $application, TokenInterface $token)
    {
        /** @var User $current_user */
        $current_user = $this->security->getUser();

        if (!$current_user instanceof User) {
            return false;
        }

        switch($attribute) {
            case 'READ_APPLICATION':
                return $current_user->isAdmin() ||
                        $current_user->getId() == $application->getJob()->getCustomer()->getUser()->getId() ||
                        $current_user->getId() == $application->getMechanic()->getUser()->getId()
                    ;
            case 'CREATE_APPLICATION':
                return $current_user->isAdmin() || $current_user->getMechanic() !== null;
        }
    }

}