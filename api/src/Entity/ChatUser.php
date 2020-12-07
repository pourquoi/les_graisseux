<?php

namespace App\Entity;

use ApiPlatform\Core\Annotation\ApiProperty;
use ApiPlatform\Core\Annotation\ApiResource;
use App\Repository\ChatUserRepository;
use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Annotation\Groups;

/**
 * @ApiResource(
 *     normalizationContext={"groups"={"read", "chat_user:read"}},
 *     denormalizationContext={"groups"={"write", "chat_user:write"}},
 *     collectionOperations={
 *     },
 *     itemOperations={
 *       "get"={
 *         "controller"=NotFoundAction::class,
 *         "read"=false,
 *         "output"=false,
 *        },
 *     }
 * )
 * @ORM\Entity(repositoryClass=ChatUserRepository::class)
 */
class ChatUser
{
    use Traits\TimestampTrait;

    /**
     * @ORM\Id
     * @ORM\GeneratedValue
     * @ORM\Column(type="integer")
     * @ApiProperty(writable=false)
     * @Groups("read")
     */
    private $id;

    /**
     * @var User
     * @ORM\ManyToOne(targetEntity="User")
     * @ORM\JoinColumn(nullable=false)
     * @Groups("read")
     */
    protected $user;

    /**
     * @var \DateTime|null
     * @ORM\Column(nullable=true, type="datetime")
     * @Groups("read")
     */
    protected $readAt;

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

    public function getReadAt(): ?\DateTime
    {
        return $this->readAt;
    }

    public function setReadAt(?\DateTime $readAt): self
    {
        $this->readAt = $readAt;
        return $this;
    }

}
