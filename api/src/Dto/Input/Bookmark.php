<?php

namespace App\Dto\Input;

use Symfony\Component\Serializer\Annotation\Groups;

class Bookmark
{
    /**
     * @var \App\Entity\User
     * @Groups("write")
     */
    public $user;

    /**
     * @var \App\Entity\Job
     * @Groups("write")
     */
    public $job;

    /**
     * @var \App\Entity\UserVehicle
     * @Groups("write")
     */
    public $vehicle;
}