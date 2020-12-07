<?php

namespace App\Dto\Input;

use Symfony\Component\Serializer\Annotation\Groups;
use Symfony\Component\Validator\Constraints as Assert;

final class Register
{
    /**
     * @var string
     * @Groups({"write"})
     * @Assert\Email()
     */
    public $email;

    /**
     * @var string
     * @Groups({"write"})
     */
    public $password;
}