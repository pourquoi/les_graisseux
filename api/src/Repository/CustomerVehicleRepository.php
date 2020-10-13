<?php

namespace App\Repository;

use App\Entity\CustomerVehicle;
use Doctrine\Bundle\DoctrineBundle\Repository\ServiceEntityRepository;
use Doctrine\Persistence\ManagerRegistry;

/**
 * @method CustomerVehicle|null find($id, $lockMode = null, $lockVersion = null)
 * @method CustomerVehicle|null findOneBy(array $criteria, array $orderBy = null)
 * @method CustomerVehicle[]    findAll()
 * @method CustomerVehicle[]    findBy(array $criteria, array $orderBy = null, $limit = null, $offset = null)
 */
class CustomerVehicleRepository extends ServiceEntityRepository
{
    public function __construct(ManagerRegistry $registry)
    {
        parent::__construct($registry, CustomerVehicle::class);
    }

    // /**
    //  * @return CustomerVehicle[] Returns an array of CustomerVehicle objects
    //  */
    /*
    public function findByExampleField($value)
    {
        return $this->createQueryBuilder('c')
            ->andWhere('c.exampleField = :val')
            ->setParameter('val', $value)
            ->orderBy('c.id', 'ASC')
            ->setMaxResults(10)
            ->getQuery()
            ->getResult()
        ;
    }
    */

    /*
    public function findOneBySomeField($value): ?CustomerVehicle
    {
        return $this->createQueryBuilder('c')
            ->andWhere('c.exampleField = :val')
            ->setParameter('val', $value)
            ->getQuery()
            ->getOneOrNullResult()
        ;
    }
    */
}
