<?php

namespace App\Repository;

use App\Entity\UserVehicle;
use Doctrine\Bundle\DoctrineBundle\Repository\ServiceEntityRepository;
use Doctrine\Persistence\ManagerRegistry;

/**
 * @method UserVehicle|null find($id, $lockMode = null, $lockVersion = null)
 * @method UserVehicle|null findOneBy(array $criteria, array $orderBy = null)
 * @method UserVehicle[]    findAll()
 * @method UserVehicle[]    findBy(array $criteria, array $orderBy = null, $limit = null, $offset = null)
 */
class UserVehicleRepository extends ServiceEntityRepository
{
    public function __construct(ManagerRegistry $registry)
    {
        parent::__construct($registry, UserVehicle::class);
    }
}
