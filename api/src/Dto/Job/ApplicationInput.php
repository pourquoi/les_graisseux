<?php

namespace App\Dto\Job;

use App\Entity\Job;
use App\Entity\Mechanic;
use Symfony\Component\Serializer\Annotation\Groups;

class ApplicationInput
{
    /**
     * @var Mechanic
     * @Groups({"write"})
     */
    public $mechanic;

    /**
     * @var Job
     * @Groups({"write"})
     */
    public $job;

    /**
     * @var string
     * @Groups({"write"})
     */
    public $message;
}