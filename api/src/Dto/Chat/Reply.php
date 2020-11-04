<?php

namespace App\Dto\Chat;

use App\Entity\ChatRoom;
use App\Entity\User;
use Symfony\Component\Serializer\Annotation\Groups;

class Reply
{
    /**
     * @var ChatRoom
     * @Groups("write")
     */
    public $room;

    /**
     * @var string
     * @Groups("write")
     */
    public $message;

    /**
     * @var User
     * @Groups("write")
     */
    public $user;
}