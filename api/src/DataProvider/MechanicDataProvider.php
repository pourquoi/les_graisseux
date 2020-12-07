<?php

namespace App\DataProvider;

use ApiPlatform\Core\DataProvider\CollectionDataProviderInterface;
use ApiPlatform\Core\DataProvider\ContextAwareCollectionDataProviderInterface;
use ApiPlatform\Core\DataProvider\DenormalizedIdentifiersAwareItemDataProviderInterface;
use ApiPlatform\Core\DataProvider\ItemDataProviderInterface;
use ApiPlatform\Core\DataProvider\RestrictedDataProviderInterface;
use App\Entity\Mechanic;
use Doctrine\ORM\EntityManagerInterface;
use Doctrine\ORM\Tools\Pagination\Paginator;
use Symfony\Component\Security\Core\Security;

class MechanicDataProvider implements ContextAwareCollectionDataProviderInterface, RestrictedDataProviderInterface, DenormalizedIdentifiersAwareItemDataProviderInterface
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
        $user = $this->security->getUser();

        $qb = $this->em->createQueryBuilder()->select('m')
            ->from(Mechanic::class, 'm')
            ->innerJoin('m.user', 'u')
            ->innerJoin('u.address', 'addr')
            ->leftJoin('m.services', 'services')
            ->leftJoin('services.vehicle', 'v1')
            ->leftJoin('services.service', 'service')
            ->leftJoin('v1.parent', 'v2')
            ->leftJoin('v2.parent', 'v3')
            ->leftJoin('v3.parent', 'v4')
        ;

        if (isset($context['filters']['distance'])) {
            [$lat, $lng, $radius] = explode(',', $context['filters']['distance']);

            $qb->addSelect(
                '(
                  6371 * acos(
                    cos(radians(:lat)) * cos(radians(y(addr.coordinates))) * cos(radians(x(addr.coordinates)) - radians(:lng))
                    +
                    sin(radians(:lat)) * sin(radians(y(addr.coordinates)))
                  )
                ) AS distance'
            )
                ->setParameter('lat', $lat)
                ->setParameter('lng', $lng)
                ->having('distance <= :radius')
                ->setParameter('radius', $radius);
        }

        if (isset($context['filters']['vehicle'])) {
            $types = explode(',', $context['filters']['vehicle']);
            $qb
                ->andWhere('((v1.id IS NOT NULL AND v1.id IN (:types)) OR (v2.id IS NOT NULL AND v2.id IN (:types)) OR (v3.id IS NOT NULL AND v3.id IN (:types)) OR (v4.id IS NOT NULL AND v4.id IN (:types)))')
                ->setParameter('types', $types)
            ;
        }

        if (isset($context['filters']['sort'])) {
            foreach($context['filters']['sort'] as $sort=>$order) {
                switch($sort) {
                    case 'distance':
                        $qb->orderBy('distance', 'ASC');
                        break;
                    case 'new':
                        $qb->orderBy('m.created_at', 'DESC');
                        break;
                }
            }
        }

        $page = 1;
        if (isset($context['filters']['page'])) $page = (int)$context['filters']['page'];

        $query = $qb->getQuery()
            ->setFirstResult(($page-1) * 30)
            ->setMaxResults(30);

        $paginator = new Paginator($query, true);

        /** @var Mechanic $mechanic */
        foreach($paginator as $k=>$item) {
            if (is_array($item)) {
                $mechanic = $item[0];
                if (isset($item['distance'])) {
                    $mechanic->distance = $item['distance'];
                }
            } else {
                $mechanic = $item;
            }

            $this->fillContext($mechanic);
        }

        return new \ApiPlatform\Core\Bridge\Doctrine\Orm\Paginator($paginator);
    }

    public function getItem(string $resourceClass, $id, string $operationName = null, array $context = [])
    {
        $mechanic = $this->itemDataProvider->getItem($resourceClass, $id, $operationName, $context);

        if ($mechanic) {
            $this->fillContext($mechanic);
        }
        return $mechanic;
    }

    public function supports(string $resourceClass, string $operationName = null, array $context = []): bool
    {
        return $resourceClass == Mechanic::class;
    }

    private function fillContext($mechanics)
    {
        if (!is_array($mechanics) ) $mechanics = [$mechanics];

        /** @var Mechanic $mechanic */
        foreach($mechanics as $mechanic) {
            $current_user = $this->security->getUser();
        }
    }

}