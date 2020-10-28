<?php

namespace App\Dto\Chat;

use App\Entity\ChatRoom;
use App\Entity\User;

class Reply
{
    /**
     * @var ChatRoom
     */
    public $room;

    /**
     * @var string
     */
    public $message;

    /**
     * @var User
     */
    public $user;
}