<?php

namespace App\Entity\Traits;

use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Annotation\Groups;

trait TimestampTrait
{
    /**
     * @ORM\Column(type="datetime", nullable=false)
     * @Groups({"read"})
     */
    protected $created_at;

    /**
     * @ORM\Column(type="datetime", nullable=true)
     * @Groups({"read"})
     */
    protected $updated_at;

    public function getCreatedAt(): ?\DateTimeInterface
    {
        return $this->created_at;
    }

    public function setCreatedAt(\DateTimeInterface $created_at): void
    {
        $this->created_at = $created_at;
    }

    public function getUpdatedAt(): ?\DateTimeInterface
    {
        return $this->updated_at;
    }

    public function setUpdatedAt(?\DateTimeInterface $updated_at): void
    {
        $this->updated_at = $updated_at;
    }
}