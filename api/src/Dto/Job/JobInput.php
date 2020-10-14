<?php

namespace App\Dto\Job;

use App\Entity\Address;
use Symfony\Component\Serializer\Annotation\Groups;

class JobInput
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
     * @Groups({"write"})
     */
    public $immobilized;

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
     * @var array
     * @Groups({"write"})
     */
    public $tasks;

    /**
     * @var int
     * @Groups({"write"})
     */
    public $customer;

    /**
     * @var int
     * @Groups({"write"})
     */
    public $vehicle;

    /**
     * @var Address
     * @Groups({"write"})
     */
    public $address;
}