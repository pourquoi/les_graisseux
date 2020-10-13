<?php

namespace App\Dto\Chat;

final class CreateChat
{
    /**
     * @var int|null
     */
    public $from;

    /**
     * @var int|null
     */
    public $to;

    /**
     * @var string|null
     */
    public $message;

    /**
     * @var int|null
     */
    public $application;
}