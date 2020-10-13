<?php

namespace App\Entity;

use ApiPlatform\Core\Annotation\ApiResource;
use App\Repository\ChatMessageRepository;
use Doctrine\ORM\Mapping as ORM;
use App\Dto\Chat;

/**
 * @ApiResource(
 *     collectionOperations={
 *         "get",
 *         "create": {
 *             "method"="POST",
 *             "input"=Chat\Reply::class
 *         }
 *     }
 * )
 * @ORM\Entity(repositoryClass=ChatMessageRepository::class)
 */
class ChatMessage
{
    use Traits\TimestampTrait;

    /**
     * @ORM\Id
     * @ORM\GeneratedValue
     * @ORM\Column(type="integer")
     */
    private $id;

    /**
     * @var string
     * @ORM\Column(type="text")
     */
    protected $message;

    /**
     * @var ChatUser
     * @ORM\ManyToOne(targetEntity="ChatUser")
     * @ORM\JoinColumn(nullable=false)
     */
    protected $user;

    /**
     * @var ChatRoom
     * @ORM\ManyToOne(targetEntity="ChatRoom")
     * @ORM\JoinColumn(nullable=false)
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
