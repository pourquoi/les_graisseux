<?php

namespace App\EventSubscriber;

use ApiPlatform\Core\EventListener\EventPriorities;
use App\Entity\ChatRoom;
use App\Entity\ChatUser;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Component\EventDispatcher\EventSubscriberInterface;
use Symfony\Component\HttpKernel\Event\RequestEvent;
use Symfony\Component\HttpKernel\Event\ViewEvent;
use Symfony\Component\HttpKernel\KernelEvents;
use Symfony\Component\Security\Core\Security;

class ChatEventSubscriber implements EventSubscriberInterface
{
    private $security;
    private $em;

    public function __construct(Security $security, EntityManagerInterface $em)
    {
        $this->security = $security;
        $this->em = $em;
    }

    public static function getSubscribedEvents()
    {
        return [
            KernelEvents::REQUEST => ['updateReadDate', EventPriorities::POST_READ]
        ];
    }

    public function updateReadDate(RequestEvent $event): void
    {
        $user = $this->security->getUser();
        if (!$user) {
            return;
        }

        $room = $event->getRequest()->attributes->get('data');

        if (!($room instanceof ChatRoom) || $event->getRequest()->getMethod() != 'GET') {
            return;
        }

        /** @var ChatUser $chatUser */
        $chatUser = $this->em->getRepository(ChatUser::class)->findOneByRoomAndUser($room, $user);
        if ($chatUser) {
            $chatUser->setReadAt(new \DateTime());
            $this->em->flush();
        }
    }
}