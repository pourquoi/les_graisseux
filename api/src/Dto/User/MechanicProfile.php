<?php

namespace App\Dto\User;

use App\Entity\Address;
use App\Entity\MechanicService;
use App\Entity\User;
use Symfony\Component\Serializer\Annotation\Groups;

class MechanicProfile
{
    /**
     * @var User
     * @Groups({"write"})
     */
    public $user;

    /**
     * @var string
     * @Groups({"write"})
     */
    public $about;

    /**
     * @var int
     * @Groups({"write"})
     */
    public $years_of_experience;

    /**
     * int
     * @Groups({"write"})
     */
    public $working_range;

    /**
     * @var Address
     * @Groups({"write"})
     */
    public $address;

    /**
     * @var MechanicService[]
     * @Groups({"write"})
     */
    public $services;
}