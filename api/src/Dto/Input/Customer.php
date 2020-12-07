<?php

namespace App\Dto\Input;

use App\Entity\User;
use Symfony\Component\Serializer\Annotation\Groups;

class Customer
{
    /**
     * @var User
     * @Groups({"write"})
     */
    public $user;
}