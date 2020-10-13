<?php

namespace App\Entity\Traits;

use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Annotation\Groups;

trait PopularityTrait
{
    /**
     * @var float
     * @ORM\Column(type="float", nullable=true)
     * @Groups({"read"})
     */
    protected $popularity;

    public function getPopularity(): ?float
    {
        return $this->popularity;
    }

    public function setPopularity(?float $popularity): void
    {
        $this->popularity = $popularity;
    }
}