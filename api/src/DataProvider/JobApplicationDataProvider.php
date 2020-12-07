<?php

namespace App\DataProvider;

use ApiPlatform\Core\DataProvider\CollectionDataProviderInterface;
use ApiPlatform\Core\DataProvider\ContextAwareCollectionDataProviderInterface;
use ApiPlatform\Core\DataProvider\DenormalizedIdentifiersAwareItemDataProviderInterface;
use ApiPlatform\Core\DataProvider\ItemDataProviderInterface;
use ApiPlatform\Core\DataProvider\RestrictedDataProviderInterface;
use App\Entity\JobApplication;
use Doctrine\ORM\EntityManagerInterface;
use Doctrine\ORM\Tools\Pagination\Paginator;
use Symfony\Component\HttpFoundation\RequestStack;
use Symfony\Component\Security\Core\Security;

class JobApplicationDataProvider implements ContextAwareCollectionDataProviderInterface, RestrictedDataProviderInterface, DenormalizedIdentifiersAwareItemDataProviderInterface
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

        $qb = $this->em->createQueryBuilder()
            ->select('app')
            ->from(JobApplication::class, 'app')
            ->innerJoin('app.mechanic', 'mechanic')
            ->innerJoin('app.job', 'job')
            ->innerJoin('mechanic.user', 'mechanic_user')
            ->innerJoin('job.customer', 'customer')
            ->innerJoin('customer.user', 'customer_user')
        ;

        if ($this->security->isGranted('ROLE_ADMIN') && (isset($context['filters']['mechanic']) || isset($context['filters']['job.customer'])) ) {
            if (isset($context['filters']['mechanic'])) {
                $qb->andWhere('mechanic.id = :mechanic')->setParameter('mechanic', $context['filters']['mechanic']);
            }

            if (isset($context['filters']['job.customer'])) {
                $qb->andWhere('customer.id = :customer')->setParameter('customer', $context['filters']['job.customer']);
            }
        } else {
            $qb->andWhere('customer.user = :user OR mechanic.user = :user')->setParameter('user', $user);
        }

        if (isset($context['filters']['job'])) {
            $qb->andWhere('job.id = :job')->setParameter('job', $context['filters']['job']);
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
        $application = $this->itemDataProvider->getItem($resourceClass, $id, $operationName, $context);
        $this->fillContext($application);
        return $application;
    }

    public function supports(string $resourceClass, string $operationName = null, array $context = []): bool
    {
        return $resourceClass === JobApplication::class;
    }

    private function fillContext($applications)
    {

    }
}