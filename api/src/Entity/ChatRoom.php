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
use Symfony\Component\Serializer\Annotation\Groups;

/**
 * @ApiResource(
 *     normalizationContext={"groups"={"read", "chat_room:read"}},
 *     denormalizationContext={"groups"={"write", "chat_room:write"}},
 *     security="is_granted('ROLE_USER')",
 *     subresourceOperations={
 *       "api_chat_rooms_messages_get_subresource"={
 *         "method"="GET",
 *         "normalization_context"={"groups"={"sdfdsf"}}
 *       }
 *     },
 *     collectionOperations={
 *          "get" = {
 *          },
 *          "post"={
 *              "method"="POST",
 *              "input"=Chat\CreateChat::class,
 *              "normalization_context"={"groups"={"read", "chat_room:read", "chat_room:messages:read"}},
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
     * @Groups("read")
     */
    private $id;

    /**
     * @ApiProperty(identifier=true)
     * @var UuidInterface
     * @ORM\Column(type="uuid", unique=true)
     * @Groups("read")
     */
    protected $uuid;

    /**
     * @var ChatUser[]|ArrayCollection
     * @ORM\OneToMany(targetEntity="ChatUser", mappedBy="room", cascade={"persist", "remove"})
     * @Groups("chat_room:read")
     */
    protected $users;

    /**
     * @var JobApplication
     * @ORM\OneToOne(targetEntity="JobApplication", mappedBy="chat")
     * @Groups("chat_room:read")
     */
    protected $application;

    /**
     * @var ChatMessage[]|ArrayCollection
     * @ORM\OneToMany(targetEntity="ChatMessage", mappedBy="room", cascade={"persist", "remove"})
     * @Groups("chat_room:messages:read")
     * @ApiSubresource()
     */
    protected $messages;

    /**
     * @var ChatMessage|null
     * @ApiProperty()
     * @Groups("chat_room:read")
     */
    public $last_message;

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
