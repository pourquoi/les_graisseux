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
use Symfony\Component\Security\Core\Security;

class ChatRoomDataProvider implements ContextAwareCollectionDataProviderInterface, RestrictedDataProviderInterface, DenormalizedIdentifiersAwareItemDataProviderInterface
{
    private $em;
    private $security;
    private $itemDataProvider;
    private $collectionDataProvider;

    public function __construct(EntityManagerInterface $em, Security $security, ItemDataProviderInterface $itemDataProvider, CollectionDataProviderInterface $collectionDataProvider)
    {
        $this->em = $em;
        $this->security = $security;
        $this->itemDataProvider = $itemDataProvider;
        $this->collectionDataProvider = $collectionDataProvider;
    }

    public function getCollection(string $resourceClass, string $operationName = null, array $context = [])
    {
        $items = $this->collectionDataProvider->getCollection($resourceClass, $operationName, $context);
        foreach($items as $item) {
            $this->fillContext($item);
        }
        return $items;
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

        /** @var ChatRoom $room */
        foreach($rooms as $room) {
            $messages = $this->em->getRepository(ChatMessage::class)->findBy(['room' => $room], ['created_at'=>'desc'], 1);
            if (count($messages)) $room->last_message = $messages[0];
        }
    }
}