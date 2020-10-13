<?php

namespace App\Dto\User;

use Symfony\Component\Serializer\Annotation\Groups;

class CustomerProfile
{
    /**
     * @var int
     * @Groups({"write"})
     */
    public $user;
}