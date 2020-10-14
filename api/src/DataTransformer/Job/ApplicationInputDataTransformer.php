<?php

namespace App\DataTransformer\Job;

use ApiPlatform\Core\DataTransformer\DataTransformerInterface;
use App\Dto\Job\ApplicationInput;
use App\Entity\ChatMessage;
use App\Entity\ChatRoom;
use App\Entity\ChatUser;
use App\Entity\JobApplication;
use App\Entity\User;
use App\Repository\JobApplicationRepository;
use App\Repository\JobRepository;
use App\Repository\MechanicRepository;
use Symfony\Component\Security\Core\Security;

class ApplicationInputDataTransformer implements DataTransformerInterface
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
     * @param ApplicationInput $data
     * @param string $to
     * @param array $context
     * @return object|void
     */
    public function transform($data, string $to, array $context = [])
    {
        $application = new JobApplication();

        /** @var User $currentUser */
        $currentUser = $this->security->getUser();

        if ($this->security->isGranted('ROLE_ADMIN') && $data->mechanic) {
            $mechanic = $this->mechanicRepository->find($data->mechanic);
        } else {
            $mechanic = $currentUser->getMechanic();
        }

        if ($mechanic === null) {
            throw new \InvalidArgumentException(sprintf('Error creating job application: mechanic %d not found', $data->mechanic));
        }

        $job = $this->jobRepository->find($data->job);
        if ($job === null) {
            throw new \InvalidArgumentException(sprintf('Error creating job application: job %d not found', $data->job));
        }

        $previous_applications = $this->applicationRepository->findBy(['job'=>$job, 'mechanic'=>$mechanic]);
        if ( count($previous_applications) ) {
            // @todo
            throw new \InvalidArgumentException();
        }

        $application->setJob($job);
        $application->setMechanic($mechanic);

        $chatRoom = new ChatRoom();
        $chatUserMechanic = new ChatUser();
        $chatUserMechanic->setUser($mechanic->getUser());
        $chatUserCustomer = new ChatUser();
        $chatUserMechanic->setUser($job->getCustomer()->getUser());
        $chatRoom->addUser($chatUserMechanic);
        $chatRoom->addUser($chatUserCustomer);

        $application->setChat($chatRoom);

        if ($data->message) {
            $message = new ChatMessage();
            $message->setMessage($data->message);
            $message->setUser($chatUserMechanic);
            $chatRoom->addMessage($message);
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