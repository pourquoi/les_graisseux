<?php

namespace App\Entity;

use ApiPlatform\Core\Annotation\ApiResource;
use App\Repository\JobApplicationRepository;
use Doctrine\ORM\Mapping as ORM;

/**
 * @ApiResource()
 * @ORM\Entity(repositoryClass=JobApplicationRepository::class)
 */
class JobApplication
{
    use Traits\TimestampTrait;

    /**
     * @ORM\Id
     * @ORM\GeneratedValue
     * @ORM\Column(type="integer")
     */
    private $id;

    /**
     * @var Job
     * @ORM\ManyToOne(targetEntity="Job", inversedBy="applications")
     * @ORM\JoinColumn(nullable=false)
     */
    protected $job;

    /**
     * @var Mechanic
     * @ORM\ManyToOne(targetEntity="Mechanic")
     * @ORM\JoinColumn(nullable=false)
     */
    protected $mechanic;

    /**
     * @var ChatRoom
     * @ORM\OneToOne(targetEntity="ChatRoom", inversedBy="application")
     */
    protected $chat;

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getJob(): Job
    {
        return $this->job;
    }

    public function setJob(Job $job): self
    {
        $this->job = $job;
        return $this;
    }

    public function getMechanic(): Mechanic
    {
        return $this->mechanic;
    }

    public function setMechanic(Mechanic $mechanic): self
    {
        $this->mechanic = $mechanic;
        return $this;
    }

    public function getChat(): ?ChatRoom
    {
        return $this->chat;
    }

    public function setChat(?ChatRoom $chat): self
    {
        $this->chat = $chat;
        return $this;
    }


}
