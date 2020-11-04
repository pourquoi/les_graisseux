<?php

namespace App\Entity;

use ApiPlatform\Core\Annotation\ApiProperty;
use ApiPlatform\Core\Annotation\ApiResource;
use App\Repository\JobApplicationRepository;
use Doctrine\ORM\Mapping as ORM;
use App\Dto\Job\ApplicationInput;
use Symfony\Component\Serializer\Annotation\Groups;

/**
 * @ApiResource(
 *     normalizationContext={"groups"={"read", "application:read"}},
 *     denormalizationContext={"groups"={"write", "application:write"}},
 *     itemOperations={
 *         "get"={
 *             "security"="is_granted('READ_APPLICATION', object)"
 *         }
 *     },
 *     collectionOperations={
 *         "get"={
 *              "method"="GET",
 *              "normalization_context"={"groups"={"read", "application:read", "application:list"}},
 *          },
 *         "post"={
 *             "method"="POST",
 *             "security"="is_granted('ROLE_ADMIN') or is_granted('ROLE_MECHANIC')",
 *             "security_post_denormalize"="is_granted('CREATE_APPLICATION', object)",
 *             "input"=ApplicationInput::class,
 *             "normalization_context"={"groups"={"read", "application:read", "application:job:read", "mechanic:read"}},
 *         }
 *     }
 * )
 * @ORM\Entity(repositoryClass=JobApplicationRepository::class)
 */
class JobApplication
{
    const STATUS_CANCEL = 'cancel';
    const STATUS_REJECTED = 'rejected';
    const STATUS_ACCEPTED = 'accepted';

    use Traits\TimestampTrait;

    /**
     * @ORM\Id
     * @ORM\GeneratedValue
     * @ORM\Column(type="integer")
     * @Groups({"read", "write"})
     * @ApiProperty(writable=false)
     */
    private $id;

    /**
     * @var string
     * @ORM\Column(nullable=true)
     * @Groups({"read"})
     */
    private $status;

    /**
     * @var Job
     * @ORM\ManyToOne(targetEntity="Job", inversedBy="applications")
     * @ORM\JoinColumn(nullable=false)
     * @Groups({"application:job:read", "application:list"})
     */
    protected $job;

    /**
     * @var Mechanic
     * @ORM\ManyToOne(targetEntity="Mechanic")
     * @ORM\JoinColumn(nullable=false)
     * @Groups({"application:job:read", "application:list"})
     */
    protected $mechanic;

    /**
     * @var ChatRoom
     * @ORM\OneToOne(targetEntity="ChatRoom", inversedBy="application", cascade={"persist", "remove"})
     * @Groups({"application:job:read", "application:list"})
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

    public function getStatus(): ?string
    {
        return $this->status;
    }

    public function setStatus(?string $status): void
    {
        $this->status = $status;
    }


}
