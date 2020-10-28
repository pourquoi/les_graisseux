<?php

namespace App\Dto\Chat;

use App\Entity\JobApplication;
use App\Entity\User;

final class CreateChat
{
    /**
     * @var User
     */
    public $from;

    /**
     * @var User
     */
    public $to;

    /**
     * @var string|null
     */
    public $message;
}