<?php

namespace App\Entity;

use ApiPlatform\Core\Annotation\ApiProperty;
use ApiPlatform\Core\Annotation\ApiResource;
use ApiPlatform\Core\Annotation\ApiSubresource;
use App\Repository\ChatRoomRepository;
use Doctrine\Common\Collections\ArrayCollection;
use Doctrine\Common\Collections\Collection;
use Doctrine\ORM\Mapping as ORM;
use Ramsey\Uuid\Uuid;
use Ramsey\Uuid\UuidInterface;
use App\Dto\Chat;

/**
 * @ApiResource(
 *     security="is_granted('ROLE_USER')",
 *     collectionOperations={
 *          "get" = {
 *          },
 *          "post"={
 *              "method"="POST",
 *              "input"=Chat\CreateChat::class,
 *          }
 *     },
 *     itemOperations={
 *         "get"
 *     }
 * )
 * @ORM\Entity(repositoryClass=ChatRoomRepository::class)
 */
class ChatRoom
{
    use Traits\TimestampTrait;

    /**
     * @ApiProperty(identifier=false, writable=false)
     * @ORM\Id
     * @ORM\GeneratedValue
     * @ORM\Column(type="integer")
     */
    private $id;

    /**
     * @ApiProperty(identifier=true)
     * @var UuidInterface
     * @ORM\Column(type="uuid", unique=true)
     */
    protected $uuid;

    /**
     * @var ChatUser[]|ArrayCollection
     * @ORM\OneToMany(targetEntity="ChatUser", mappedBy="room", cascade={"persist", "remove"})
     */
    protected $users;

    /**
     * @var JobApplication
     * @ORM\OneToOne(targetEntity="JobApplication", mappedBy="chat")
     */
    protected $application;

    /**
     * @var ChatMessage[]|ArrayCollection
     * @ORM\OneToMany(targetEntity="ChatMessage", mappedBy="room", cascade={"persist", "remove"})
     * @ApiSubresource()
     */
    protected $messages;

    public function __construct()
    {
        $this->users = new ArrayCollection();
        $this->messages = new ArrayCollection();
        $this->uuid = Uuid::uuid4();
    }

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getUuid(): UuidInterface
    {
        return $this->uuid;
    }

    public function setUuid(UuidInterface $uuid): self
    {
        $this->uuid = $uuid;
        return $this;
    }

    public function getUsers(): Collection
    {
        return $this->users;
    }

    public function addUser(ChatUser $user) {
        if (!$this->users->contains($user)) {
            $this->users->add($user);
        }
        $user->setRoom($this);
        return $this;
    }

    public function removeUser(ChatUser $user) {
        if ($this->users->contains($user)) {
            $this->users->remove($user);
        }
        return $this;
    }

    public function getApplication(): ?JobApplication
    {
        return $this->application;
    }

    public function setApplication(?JobApplication $application): self
    {
        $this->application = $application;
        return $this;
    }

    public function getMessages(): Collection
    {
        return $this->messages;
    }

    public function addMessage(ChatMessage $message): self
    {
        if (!$this->messages->contains($message)) {
            $this->messages->add($message);
        }
        $message->setRoom($this);
        return $this;
    }

    public function removeMessage(ChatMessage $message): self
    {
        if ($this->messages->contains($message)) {
            $this->messages->remove($message);
        }
        return $this;
    }
}
