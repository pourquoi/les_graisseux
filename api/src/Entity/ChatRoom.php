<?php

namespace App\Entity;

use ApiPlatform\Core\Annotation\ApiFilter;
use ApiPlatform\Core\Annotation\ApiProperty;
use ApiPlatform\Core\Annotation\ApiResource;
use ApiPlatform\Core\Annotation\ApiSubresource;
use App\Repository\ChatRoomRepository;
use Doctrine\Common\Collections\ArrayCollection;
use Doctrine\Common\Collections\Collection;
use Doctrine\ORM\Mapping as ORM;
use Ramsey\Uuid\Uuid;
use Ramsey\Uuid\UuidInterface;
use Symfony\Component\Uid\UuidV4;
use App\Dto;
use Symfony\Component\Serializer\Annotation\Groups;
use ApiPlatform\Core\Bridge\Doctrine\Orm\Filter\BooleanFilter;
use ApiPlatform\Core\Bridge\Doctrine\Orm\Filter\ExistsFilter;
use ApiPlatform\Core\Bridge\Doctrine\Orm\Filter\SearchFilter;

/**
 * @ApiResource(
 *     normalizationContext={"groups"={"read", "chat_room:read"}},
 *     denormalizationContext={"groups"={"write", "chat_room:write"}},
 *     security="is_granted('ROLE_USER')",
 *     collectionOperations={
 *          "get" = {
 *          },
 *          "post"={
 *              "method"="POST",
 *              "input"=Dto\Input\ChatRoom::class,
 *              "normalization_context"={"groups"={"read", "chat_room:read", "chat_room:messages:read"}},
 *          }
 *     },
 *     itemOperations={
 *         "get"
 *     }
 * )
 * @ORM\Entity(repositoryClass=ChatRoomRepository::class)
 * @ApiFilter(ExistsFilter::class, properties={"job", "application"})
 * @ApiFilter(BooleanFilter::class, properties={"private"})
 * @ApiFilter(SearchFilter::class, properties={"users.user"})
 * @ORM\HasLifecycleCallbacks()
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
    protected $id;

    /**
     * @ApiProperty(identifier=true)
     * @var UuidV4
     * @ORM\Column(type="uuid", unique=true)
     * @Groups("read")
     */
    protected $uuid;

    /**
     * @var bool
     * @ORM\Column(type="boolean")
     * @Groups("read")
     */
    protected $private;

    /**
     * @var ChatUser[]|ArrayCollection
     * @ORM\OneToMany(targetEntity="ChatUser", mappedBy="room", cascade={"persist", "remove"}, orphanRemoval=true)
     * @Groups("chat_room:read:users")
     */
    protected $users;

    /**
     * @var JobApplication
     * @ORM\OneToOne(targetEntity="JobApplication", mappedBy="chat")
     * @Groups("chat_room:read")
     */
    protected $application;

    /**
     * @var Job
     * @ORM\OneToOne(targetEntity="Job", mappedBy="chat")
     * @Groups("chat_room:read")
     */
    protected $job;

    /**
     * @var ChatMessage[]|ArrayCollection
     * @ORM\OneToMany(targetEntity="ChatMessage", mappedBy="room", cascade={"persist", "remove"}, orphanRemoval=true)
     */
    protected $messages;

    /**
     * @var ChatMessage|null
     * @ApiProperty()
     * @Groups("chat_room:read")
     */
    public $lastMessage;

    /**
     * @var int
     * @ApiProperty()
     * @Groups("chat_room:read")
     */
    public $unreadCount;

    /**
     * @var string
     * @ApiProperty()
     * @Groups("read")
     */
    public $title;

    public function __construct()
    {
        $this->users = new ArrayCollection();
        $this->messages = new ArrayCollection();
        $this->uuid = new UuidV4();
    }

    private function syncPrivate()
    {
        $this->private = false;
        if ($this->application != null) return;
        if ($this->job != null) return;

        if ($this->users->count()>2) return;
        $this->private = true;
    }

    /**
     * @param User $user
     * @return ChatUser|null
     */
    public function getFirstInterlocutor(?User $user) {
        if (!$user) return null;

        foreach($this->getUsers() as $chatUser) {
            if ($chatUser->getUser()->getId() != $user->getId()) return $chatUser;
        }

        return null;
    }

    /**
     * @ORM\PrePersist()
     */
    public function prePersist()
    {
        $this->syncPrivate();
    }

    /**
     * @ORM\PreUpdate()
     */
    public function preUpdate()
    {
        $this->syncPrivate();
    }

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getUuid(): UuidV4
    {
        return $this->uuid;
    }

    public function setUuid(UuidV4 $uuid): self
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
            $user->setRoom($this);
        }
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

    public function getJob(): ?Job
    {
        return $this->job;
    }

    public function setJob(?Job $job): self
    {
        $this->job = $job;
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
            $message->setRoom($this);
        }
        return $this;
    }

    public function removeMessage(ChatMessage $message): self
    {
        if ($this->messages->contains($message)) {
            $this->messages->remove($message);
        }
        return $this;
    }

    public function isPrivate(): bool
    {
        return $this->private;
    }

    public function setPrivate(bool $private): self
    {
        $this->private = $private;
        return $this;
    }
}
