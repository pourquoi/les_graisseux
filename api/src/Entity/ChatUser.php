<?php

namespace App\Entity;

use ApiPlatform\Core\Annotation\ApiResource;
use App\Repository\ChatUserRepository;
use Doctrine\ORM\Mapping as ORM;

/**
 * @ApiResource()
 * @ORM\Entity(repositoryClass=ChatUserRepository::class)
 */
class ChatUser
{
    use Traits\TimestampTrait;

    /**
     * @ORM\Id
     * @ORM\GeneratedValue
     * @ORM\Column(type="integer")
     */
    private $id;

    /**
     * @var User
     * @ORM\ManyToOne(targetEntity="User")
     * @ORM\JoinColumn(nullable=false)
     */
    protected $user;

    /**
     * @var ChatRoom
     * @ORM\ManyToOne(targetEntity="ChatRoom", inversedBy="users")
     * @ORM\JoinColumn(nullable=false)
     */
    protected $room;

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getUser(): User
    {
        return $this->user;
    }

    public function setUser(User $user): self
    {
        $this->user = $user;
        return $this;
    }

    public function getRoom(): ChatRoom
    {
        return $this->room;
    }

    public function setRoom(ChatRoom $room): self
    {
        $this->room = $room;
        return $this;
    }


}
