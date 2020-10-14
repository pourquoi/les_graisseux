<?php

namespace App\Dto\Job;

use Symfony\Component\Serializer\Annotation\Groups;

class ApplicationInput
{
    /**
     * @var int
     * @Groups({"write"})
     */
    public $mechanic;

    /**
     * @var int
     * @Groups({"write"})
     */
    public $job;

    /**
     * @var string
     * @Groups({"write"})
     */
    public $message;
}