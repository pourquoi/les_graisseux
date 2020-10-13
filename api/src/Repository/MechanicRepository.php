<?php

namespace App\Repository;

use App\Entity\Mechanic;
use Doctrine\Bundle\DoctrineBundle\Repository\ServiceEntityRepository;
use Doctrine\Persistence\ManagerRegistry;

/**
 * @method Mechanic|null find($id, $lockMode = null, $lockVersion = null)
 * @method Mechanic|null findOneBy(array $criteria, array $orderBy = null)
 * @method Mechanic[]    findAll()
 * @method Mechanic[]    findBy(array $criteria, array $orderBy = null, $limit = null, $offset = null)
 */
class MechanicRepository extends ServiceEntityRepository
{
    public function __construct(ManagerRegistry $registry)
    {
        parent::__construct($registry, Mechanic::class);
    }

    // /**
    //  * @return Mechanic[] Returns an array of Mechanic objects
    //  */
    /*
    public function findByExampleField($value)
    {
        return $this->createQueryBuilder('m')
            ->andWhere('m.exampleField = :val')
            ->setParameter('val', $value)
            ->orderBy('m.id', 'ASC')
            ->setMaxResults(10)
            ->getQuery()
            ->getResult()
        ;
    }
    */

    /*
    public function findOneBySomeField($value): ?Mechanic
    {
        return $this->createQueryBuilder('m')
            ->andWhere('m.exampleField = :val')
            ->setParameter('val', $value)
            ->getQuery()
            ->getOneOrNullResult()
        ;
    }
    */
}
