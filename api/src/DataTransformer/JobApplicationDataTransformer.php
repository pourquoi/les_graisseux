<?php

namespace App\DataTransformer;

use ApiPlatform\Core\DataTransformer\DataTransformerInterface;
use App\Dto;
use App\Entity\ChatMessage;
use App\Entity\ChatRoom;
use App\Entity\ChatUser;
use App\Entity\JobApplication;
use App\Entity\User;
use App\Repository\JobApplicationRepository;
use App\Repository\JobRepository;
use App\Repository\MechanicRepository;
use Symfony\Component\Security\Core\Security;

class JobApplicationDataTransformer implements DataTransformerInterface
{
    private $security;
    private $mechanicRepository;
    private $jobRepository;
    private $applicationRepository;

    public function __construct(Security $security, MechanicRepository $mechanicRepository, JobRepository $jobRepository, JobApplicationRepository $applicationRepository)
    {
        $this->security = $security;
        $this->mechanicRepository = $mechanicRepository;
        $this->jobRepository = $jobRepository;
        $this->applicationRepository = $applicationRepository;
    }

    /**
     * @param Dto\Input\JobApplication $data
     * @param string $to
     * @param array $context
     * @return JobApplication
     */
    public function transform($data, string $to, array $context = [])
    {
        $application = new JobApplication();

        /** @var User $currentUser */
        $currentUser = $this->security->getUser();

        if ($this->security->isGranted('ROLE_ADMIN') && $data->mechanic) {
            $mechanic = $data->mechanic;
        } else {
            $mechanic = $currentUser->getMechanic();
        }

        if ($mechanic === null) {
            throw new \InvalidArgumentException('Error creating job application: mechanic required');
        }

        if ($data->job === null) {
            throw new \InvalidArgumentException('Error creating job application: job required');
        }

        if ($mechanic->getUser() === $data->job->getCustomer()->getUser()) {
            throw new \InvalidArgumentException('Error creating job application: cannot self apply');
        }

        $previous_applications = $this->applicationRepository->findBy(['job'=>$data->job, 'mechanic'=>$mechanic]);
        if ( count($previous_applications) ) {
            $application = $previous_applications[0];
        }

        $application->setJob($data->job);
        $application->setMechanic($mechanic);

        if ($application->getChat() === null) {
            $chatRoom = new ChatRoom();
            $chatUserMechanic = new ChatUser();
            $chatUserMechanic->setUser($mechanic->getUser());
            $chatUserCustomer = new ChatUser();
            $chatUserCustomer->setUser($data->job->getCustomer()->getUser());
            $chatRoom->addUser($chatUserMechanic);
            $chatRoom->addUser($chatUserCustomer);

            $application->setChat($chatRoom);

            if ($data->message) {
                $message = new ChatMessage();
                $message->setMessage($data->message);
                $message->setUser($chatUserMechanic);
                $chatRoom->addMessage($message);
            }
        }

        return $application;
    }

    public function supportsTransformation($data, string $to, array $context = []): bool
    {
        if ($data instanceof JobApplication) {
            return false;
        }

        return $to === JobApplication::class && null !== ($context['input']['class'] ?? null);
    }

}