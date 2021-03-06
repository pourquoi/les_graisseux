<?php

namespace App\Entity;

use ApiPlatform\Core\Annotation\ApiFilter;
use ApiPlatform\Core\Annotation\ApiProperty;
use ApiPlatform\Core\Annotation\ApiResource;
use App\Repository\ChatMessageRepository;
use Doctrine\ORM\Mapping as ORM;
use ApiPlatform\Core\Action\NotFoundAction;
use ApiPlatform\Core\Bridge\Doctrine\Orm\Filter\SearchFilter;
use App\Dto;
use Symfony\Component\Serializer\Annotation\Groups;

/**
 * @ApiResource(
 *     normalizationContext={"groups"={"read", "chat_message:read"}},
 *     denormalizationContext={"groups"={"write", "chat_message:write"}},
 *     graphql = {
 *         "collection_query" = {
 *             "normalization_context"={"groups"={"read", "chat_message:read", "chat_message:read:room"}}
 *         }
 *     },
 *     collectionOperations={
 *         "get" = {
 *         },
 *         "get_list" = {
 *             "method" = "GET",
 *             "path" = "/chat_messages/feed",
 *             "normalization_context"={"groups"={"read", "chat_message:read", "chat_message:read:room"}},
 *         },
 *         "post": {
 *             "method"="POST",
 *             "security"="is_granted('ROLE_USER')",
 *             "input"=Dto\Input\ChatMessage::class,
 *             "normalization_context"={"groups"={"read", "chat_message:read", "chat_message:read:room"}}
 *         }
 *     },
 *     itemOperations={
 *         "get"={},
 *     }
 * )
 * @ORM\Entity(repositoryClass=ChatMessageRepository::class)
 * @ApiFilter(SearchFilter::class, properties={"room.uuid"})
 */
class ChatMessage
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
     * @var string
     * @ORM\Column(type="text")
     * @Groups("read")
     */
    protected $message;

    /**
     * @var ChatUser
     * @ORM\ManyToOne(targetEntity="ChatUser")
     * @ORM\JoinColumn(nullable=false)
     * @Groups("read")
     */
    protected $user;

    /**
     * @var ChatRoom
     * @ORM\ManyToOne(targetEntity="ChatRoom", inversedBy="messages")
     * @ORM\JoinColumn(nullable=false, name="room_id", referencedColumnName="id", onDelete="cascade")
     * @Groups({"chat_message:read:room", "chat_message:write"})
     */
    protected $room;

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getMessage(): string
    {
        return $this->message;
    }

    public function setMessage(string $message): self
    {
        $this->message = $message;
        return $this;
    }

    public function getUser(): ChatUser
    {
        return $this->user;
    }

    public function setUser(ChatUser $user): self
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
