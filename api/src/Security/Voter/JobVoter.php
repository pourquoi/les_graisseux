<?php

namespace App\Security\Voter;

use App\Entity\Job;
use App\Entity\User;
use Symfony\Component\Security\Core\Authentication\Token\TokenInterface;
use Symfony\Component\Security\Core\Authorization\Voter\Voter;
use Symfony\Component\Security\Core\Security;

class JobVoter extends Voter
{
    private $security = null;

    public function __construct(Security $security)
    {
        $this->security = $security;
    }

    protected function supports(string $attribute, $subject)
    {
        $supportsAttribute = in_array($attribute, ['CREATE_JOB', 'EDIT_JOB', 'DELETE_JOB']);
        $supportsSubject = $subject instanceof Job;

        return $supportsAttribute && $supportsSubject;
    }

    /**
     * @param string $attribute
     * @param Job $job
     * @param TokenInterface $token
     * @return bool|void
     */
    protected function voteOnAttribute(string $attribute, $job, TokenInterface $token)
    {
        /** @var User $current_user */
        $current_user = $this->security->getUser();

        if (!$current_user instanceof User) {
            return false;
        }

        switch($attribute) {
            case 'CREATE_JOB':
            case 'EDIT_JOB':
            case 'DELETE_JOB';
                if ($current_user->isAdmin())
                    return true;

                return $current_user->getId() == $job->getCustomer()->getUser()->getId();
        }
    }

}