<?php

namespace App\Repository;

use App\Entity\VehicleTree;
use Doctrine\Bundle\DoctrineBundle\Repository\ServiceEntityRepository;
use Doctrine\Persistence\ManagerRegistry;

/**
 * @method VehicleTree|null find($id, $lockMode = null, $lockVersion = null)
 * @method VehicleTree|null findOneBy(array $criteria, array $orderBy = null)
 * @method VehicleTree[]    findAll()
 * @method VehicleTree[]    findBy(array $criteria, array $orderBy = null, $limit = null, $offset = null)
 */
class VehicleTreeRepository extends ServiceEntityRepository
{
    public function __construct(ManagerRegistry $registry)
    {
        parent::__construct($registry, VehicleTree::class);
    }
}
