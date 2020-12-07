<?php

namespace App\Repository;

use App\Entity\ProviderContext;
use Doctrine\Bundle\DoctrineBundle\Repository\ServiceEntityRepository;
use Doctrine\Persistence\ManagerRegistry;

/**
 * @method ProviderContext|null find($id, $lockMode = null, $lockVersion = null)
 * @method ProviderContext|null findOneBy(array $criteria, array $orderBy = null)
 * @method ProviderContext[]    findAll()
 * @method ProviderContext[]    findBy(array $criteria, array $orderBy = null, $limit = null, $offset = null)
 */
class ProviderContextRepository extends ServiceEntityRepository
{
    public function __construct(ManagerRegistry $registry)
    {
        parent::__construct($registry, ProviderContext::class);
    }
}
