<?php

namespace App\Dto\User;

use App\Entity\User;
use Symfony\Component\Serializer\Annotation\Groups;

class CustomerProfile
{
    /**
     * @var User
     * @Groups({"write"})
     */
    public $user;
}