<?php

namespace App\DataProvider;

use ApiPlatform\Core\DataProvider\CollectionDataProviderInterface;
use ApiPlatform\Core\DataProvider\ContextAwareCollectionDataProviderInterface;
use ApiPlatform\Core\DataProvider\DenormalizedIdentifiersAwareItemDataProviderInterface;
use ApiPlatform\Core\DataProvider\ItemDataProviderInterface;
use ApiPlatform\Core\DataProvider\RestrictedDataProviderInterface;
use App\Entity\Job;
use App\Entity\User;
use Doctrine\ORM\EntityManagerInterface;
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
        /** @var \ApiPlatform\Core\Bridge\Doctrine\Orm\Paginator $items */
        $items = $this->collectionDataProvider->getCollection($resourceClass, $operationName, $context);
        $current_user = $this->security->getUser();

        /** @var Job $job */
        foreach($items as $k=>$item) {
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

        return $items;
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