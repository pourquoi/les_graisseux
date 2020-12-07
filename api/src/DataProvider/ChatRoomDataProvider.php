<?php

namespace App\DataProvider;

use ApiPlatform\Core\DataProvider\CollectionDataProviderInterface;
use ApiPlatform\Core\DataProvider\ContextAwareCollectionDataProviderInterface;
use ApiPlatform\Core\DataProvider\DenormalizedIdentifiersAwareItemDataProviderInterface;
use ApiPlatform\Core\DataProvider\ItemDataProviderInterface;
use ApiPlatform\Core\DataProvider\RestrictedDataProviderInterface;
use App\Entity\ChatMessage;
use App\Entity\ChatRoom;
use App\Entity\ChatUser;
use Doctrine\ORM\EntityManagerInterface;
use Doctrine\ORM\Tools\Pagination\Paginator;
use Symfony\Component\HttpFoundation\RequestStack;
use Symfony\Component\Security\Core\Security;

class ChatRoomDataProvider implements ContextAwareCollectionDataProviderInterface, RestrictedDataProviderInterface, DenormalizedIdentifiersAwareItemDataProviderInterface
{
    private $em;
    private $security;
    private $itemDataProvider;
    private $collectionDataProvider;
    private $requestStack;

    public function __construct(EntityManagerInterface $em, Security $security, RequestStack $requestStack, ItemDataProviderInterface $itemDataProvider, CollectionDataProviderInterface $collectionDataProvider)
    {
        $this->em = $em;
        $this->security = $security;
        $this->itemDataProvider = $itemDataProvider;
        $this->collectionDataProvider = $collectionDataProvider;
        $this->requestStack = $requestStack;
    }

    public function getCollection(string $resourceClass, string $operationName = null, array $context = [])
    {
        $user = $this->security->getUser();

        $qb = $this->em->createQueryBuilder()->select('chat')
                ->from(ChatRoom::class, 'chat')
                ->leftJoin('chat.users', 'chat_users')
                ->leftJoin('chat_users.user', 'users')
                ->leftJoin('chat.job', 'job')
        ;

        if (!$user) {
            $qb->andWhere('job.id IS NOT NULL AND chat.private = 0');
        } else {
            if (isset($context['filters']['users.user'])) {
                $qb->leftJoin('chat.users', 'interlocutor')
                    ->andWhere('interlocutor.user = :interlocutor')
                    ->setParameter('interlocutor', $context['filters']['users.user']);
            }

            if (isset($context['filters']['private'])) {
                $qb->andWhere('chat.private = :private')
                    ->setParameter('private', $context['filters']['private'] == 'true');
            }

            $qb->leftJoin('chat.users', 'chat_users2')
                ->leftJoin('chat_users2.user', 'users2')
                ->andWhere('users2 = :user')->setParameter('user', $user);
        }

        $page = 1;
        if (isset($context['filters']['page'])) $page = (int)$context['filters']['page'];

        $query = $qb->getQuery()
            ->setFirstResult(($page-1) * 30)
            ->setMaxResults(30);

        $paginator = new Paginator($query, true);

        foreach($paginator as $item) {
            $this->fillContext($item);
        }

        return new \ApiPlatform\Core\Bridge\Doctrine\Orm\Paginator($paginator);
    }

    public function getItem(string $resourceClass, $id, string $operationName = null, array $context = [])
    {
        $room = $this->itemDataProvider->getItem($resourceClass, $id, $operationName, $context);
        $this->fillContext($room);
        return $room;
    }

    public function supports(string $resourceClass, string $operationName = null, array $context = []): bool
    {
        return $resourceClass == ChatRoom::class;
    }

    private function fillContext($rooms)
    {
        if (!is_array($rooms)) $rooms = [$rooms];

        $user = $this->security->getUser();

        /** @var ChatRoom $room */
        foreach($rooms as $room) {
            if ($user) {
                /** @var ChatUser $chatUser */
                $chatUser = $this->em->createQueryBuilder()->select('u')
                    ->from(ChatUser::class, 'u')
                    ->andWhere('u.room = :room')->setParameter('room', $room)
                    ->andWhere('u.user = :user')->setParameter('user', $user)
                    ->getQuery()->getOneOrNullResult();

                if ($chatUser) {
                    if ($chatUser->getReadAt() === null) {
                        $room->unreadCount = $this->em->createQuery('SELECT COUNT(m.id) FROM ' . ChatMessage::class . ' m WHERE m.room = :room')
                            ->setParameter('room', $room)
                            ->getSingleScalarResult();
                    } else {
                        $room->unreadCount = $this->em->createQueryBuilder()->select('COUNT(m.id)')
                            ->from(ChatMessage::class, 'm')
                            ->innerJoin('m.user', 'chat_user')
                            ->andWhere('chat_user.user != :user')->setParameter('user', $user)
                            ->andWhere('m.room = :room')->setParameter('room', $room)
                            ->andWhere('m.created_at > :posted_after')->setParameter('posted_after', $chatUser->getReadAt())
                            ->getQuery()->getSingleScalarResult();
                    }
                }
            }

            $messages = $this->em->getRepository(ChatMessage::class)->findBy(['room' => $room], ['created_at'=>'desc'], 1);
            if (count($messages)) $room->lastMessage = $messages[0];
        }
    }
}