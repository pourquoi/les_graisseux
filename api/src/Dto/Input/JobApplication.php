<?php

namespace App\Dto\Input;

use App\Entity\Job;
use App\Entity\Mechanic;
use Symfony\Component\Serializer\Annotation\Groups;

class JobApplication
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