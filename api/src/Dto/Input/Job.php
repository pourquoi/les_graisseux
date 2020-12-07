<?php

namespace App\Dto\Input;

use ApiPlatform\Core\Annotation\ApiProperty;
use App\Entity\Address;
use App\Entity\Customer;
use App\Entity\CustomerVehicle;
use App\Entity\MediaObject;
use App\Entity\ServiceTree;
use App\Entity\UserVehicle;
use Doctrine\Common\Collections\Collection;
use Symfony\Component\Serializer\Annotation\Groups;
use Symfony\Component\Validator\Constraints as Assert;

class Job
{
    /**
     * @var string
     * @Groups({"write"})
     */
    public $title;

    /**
     * @var string
     * @Groups({"write"})
     */
    public $description;

    /**
     * @var bool
     * @ApiProperty(required=false)
     * @Groups({"write"})
     */
    public $immobilized = false;

    /**
     * @var int
     * @Groups({"write"})
     */
    public $moving_range;

    /**
     * @var bool
     * @Groups({"write"})
     */
    public $urgent = false;

    /**
     * @var ServiceTree[]
     * @Groups({"write"})
     */
    public $tasks;

    /**
     * @var Customer
     * @ApiProperty(required=false)
     * @Groups({"write"})
     */
    public $customer;

    /**
     * @var UserVehicle
     * @ApiProperty(required=false)
     * @Groups({"write"})
     */
    public $vehicle;

    /**
     * @var Address
     * @Groups({"write"})
     * @Assert\NotNull()
     * @Assert\Valid()
     */
    public $address;

    /**
     * @var MediaObject[] | Collection
     * @Groups({"write"})
     */
    public $pictures;
}