<?php

namespace App\Repository;

use App\Entity\ServiceTree;
use Doctrine\Bundle\DoctrineBundle\Repository\ServiceEntityRepository;
use Doctrine\Common\Collections\Criteria;
use Doctrine\Persistence\ManagerRegistry;

/**
 * @method ServiceTree|null find($id, $lockMode = null, $lockVersion = null)
 * @method ServiceTree|null findOneBy(array $criteria, array $orderBy = null)
 * @method ServiceTree[]    findAll()
 * @method ServiceTree[]    findBy(array $criteria, array $orderBy = null, $limit = null, $offset = null)
 */
class ServiceTreeRepository extends ServiceEntityRepository
{
    public function __construct(ManagerRegistry $registry)
    {
        parent::__construct($registry, ServiceTree::class);
    }

    public function findAllByIds(array $ids)
    {
        return $this->matching(Criteria::create()->andWhere(Criteria::expr()->in('id', $ids)));
    }

    // /**
    //  * @return JobTree[] Returns an array of JobTree objects
    //  */
    /*
    public function findByExampleField($value)
    {
        return $this->createQueryBuilder('j')
            ->andWhere('j.exampleField = :val')
            ->setParameter('val', $value)
            ->orderBy('j.id', 'ASC')
            ->setMaxResults(10)
            ->getQuery()
            ->getResult()
        ;
    }
    */

    /*
    public function findOneBySomeField($value): ?JobTree
    {
        return $this->createQueryBuilder('j')
            ->andWhere('j.exampleField = :val')
            ->setParameter('val', $value)
            ->getQuery()
            ->getOneOrNullResult()
        ;
    }
    */
}
