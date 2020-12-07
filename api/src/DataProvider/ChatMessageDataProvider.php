<?php

namespace App\DataProvider;

use ApiPlatform\Core\DataProvider\CollectionDataProviderInterface;
use ApiPlatform\Core\DataProvider\ContextAwareCollectionDataProviderInterface;
use ApiPlatform\Core\DataProvider\DenormalizedIdentifiersAwareItemDataProviderInterface;
use ApiPlatform\Core\DataProvider\ItemDataProviderInterface;
use ApiPlatform\Core\DataProvider\RestrictedDataProviderInterface;
use App\Entity\ChatMessage;
use App\Entity\ChatRoom;
use Doctrine\ORM\EntityManagerInterface;
use Doctrine\ORM\Tools\Pagination\Paginator;
use Symfony\Component\HttpFoundation\RequestStack;
use Symfony\Component\Security\Core\Security;
use Symfony\Component\Uid\UuidV4;

class ChatMessageDataProvider implements ContextAwareCollectionDataProviderInterface, RestrictedDataProviderInterface, DenormalizedIdentifiersAwareItemDataProviderInterface
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

        $qb = $this->em->createQueryBuilder()->select('msg')
            ->from(ChatMessage::class, 'msg')
            ->innerJoin('msg.room', 'room')
            ->leftJoin('room.job', 'job')
        ;

        if (!$user) {
            $qb->andWhere('job.id IS NOT NULL AND room.private = 0');
        }

        if (isset($context['filters']['room.uuid'])) {
            $uuid = UuidV4::fromString($context['filters']['room.uuid']);
            $qb->andWhere('room.uuid = :uuid')->setParameter('uuid', $uuid->toBinary());
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
        return $resourceClass == ChatMessage::class;
    }

    private function fillContext($rooms)
    {

    }
}