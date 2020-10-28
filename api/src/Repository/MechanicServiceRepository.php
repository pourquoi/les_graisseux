<?php

namespace App\Repository;

use App\Entity\MechanicService;
use Doctrine\Bundle\DoctrineBundle\Repository\ServiceEntityRepository;
use Doctrine\Persistence\ManagerRegistry;

/**
 * @method MechanicService|null find($id, $lockMode = null, $lockVersion = null)
 * @method MechanicService|null findOneBy(array $criteria, array $orderBy = null)
 * @method MechanicService[]    findAll()
 * @method MechanicService[]    findBy(array $criteria, array $orderBy = null, $limit = null, $offset = null)
 */
class MechanicServiceRepository extends ServiceEntityRepository
{
    public function __construct(ManagerRegistry $registry)
    {
        parent::__construct($registry, MechanicService::class);
    }

    // /**
    //  * @return MechanicService[] Returns an array of MechanicService objects
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
    public function findOneBySomeField($value): ?MechanicService
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
