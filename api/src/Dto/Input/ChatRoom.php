<?php

namespace App\Dto\Input;

use App\Entity\JobApplication;
use App\Entity\User;
use Symfony\Component\Serializer\Annotation\Groups;

final class ChatRoom
{
    /**
     * @var User
     * @Groups("write")
     */
    public $from;

    /**
     * @var User
     * @Groups("write")
     */
    public $to;

    /**
     * @var string|null
     * @Groups("write")
     */
    public $message;
}