<?php

namespace App\DataProvider;

use ApiPlatform\Core\DataProvider\CollectionDataProviderInterface;
use ApiPlatform\Core\DataProvider\ContextAwareCollectionDataProviderInterface;
use ApiPlatform\Core\DataProvider\DenormalizedIdentifiersAwareItemDataProviderInterface;
use ApiPlatform\Core\DataProvider\ItemDataProviderInterface;
use ApiPlatform\Core\DataProvider\RestrictedDataProviderInterface;
use App\Entity\ChatRoom;
use App\Entity\Job;
use App\Entity\User;
use Doctrine\ORM\EntityManagerInterface;
use Doctrine\ORM\Tools\Pagination\Paginator;
use Symfony\Component\Security\Core\Security;

class JobDataProvider implements ContextAwareCollectionDataProviderInterface, RestrictedDataProviderInterface, DenormalizedIdentifiersAwareItemDataProviderInterface
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
        $qb = $this->em->createQueryBuilder()->select('job')
            ->from(Job::class, 'job')
            ->innerJoin('job.address', 'addr')
            ->innerJoin('job.customer', 'customer')
            ->innerJoin('customer.user', 'user')
            ->leftJoin('job.vehicle', 'vehicle')
            ->leftJoin('vehicle.type', 'v1')
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

        if (isset($context['filters']['customer.user'])) {
            $qb->andWhere('user.id = :user')->setParameter('user', $context['filters']['customer.user']);
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
                        $qb->orderBy('job.created_at', 'DESC');
                        break;
                    case 'hot':
                        $qb->orderBy('job.created_at', 'ASC');
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

        /** @var Job $job */
        foreach($paginator as $k=>$item) {
            if (is_array($item)) {
                $job = $item[0];
                if (isset($item['distance'])) {
                    $job->distance = $item['distance'];
                }
            } else {
                $job = $item;
            }

            $this->fillContext($job);
        }

        return new \ApiPlatform\Core\Bridge\Doctrine\Orm\Paginator($paginator);
    }

    public function getItem(string $resourceClass, $id, string $operationName = null, array $context = [])
    {
        $job = $this->itemDataProvider->getItem($resourceClass, $id, $operationName, $context);

        if ($job) {
            $this->fillContext($job);
        }
        return $job;
    }

    public function supports(string $resourceClass, string $operationName = null, array $context = []): bool
    {
        return $resourceClass == Job::class;
    }

    private function fillContext($jobs)
    {
        if (!is_array($jobs) ) $jobs = [$jobs];

        /** @var Job $job */
        foreach($jobs as $job) {
            $current_user = $this->security->getUser();

            if ($current_user instanceof User && $current_user->getMechanic()) {
                $application = $job->getApplications()->filter(function ($app) use ($current_user) {
                    return $app->getMechanic() === $current_user->getMechanic();
                })->first();

                $job->application = $application ? $application : null;
            }

            if ($current_user instanceof User && $current_user->getId() == $job->getCustomer()->getUser()->getId()) {
                $job->mine = true;
            } else {
                $job->mine = false;
            }
        }
    }

}