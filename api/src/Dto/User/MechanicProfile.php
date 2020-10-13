<?php

namespace App\Dto\User;

use Symfony\Component\Serializer\Annotation\Groups;

class MechanicProfile
{
    /**
     * @var int
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
     * @var array
     * @Groups({"write"})
     */
    public $services;
}