<?php

namespace App\Entity;

use ApiPlatform\Core\Annotation\ApiProperty;
use ApiPlatform\Core\Annotation\ApiResource;
use App\Repository\MechanicServiceRepository;
use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Annotation\Groups;

/**
 * @ApiResource(
 *     normalizationContext={"groups"={"read", "mechanic_service:read"}},
 *     denormalizationContext={"groups"={"write", "mechanic_service:write"}},
 *     itemOperations={
 *       "get",
 *       "put"={
 *         "method"="PUT",
 *         "security"="is_granted('ROLE_ADMIN') or (is_granted('ROLE_MECHANIC') and object.getMechanic() == user.getMechanic())"
 *       },
 *       "delete"={
 *         "method"="DELETE",
 *         "security"="is_granted('ROLE_ADMIN') or (is_granted('ROLE_MECHANIC') and object.getMechanic() == user.getMechanic())"
 *       }
 *     },
 *     collectionOperations={
 *       "post"={
 *         "method"="POST",
 *         "security"="is_granted('ROLE_MECHANIC') or is_granted('ROLE_ADMIN')",
 *         "security_post_denormalize"="is_granted('ROLE_ADMIN') or (is_granted('ROLE_MECHANIC') and object.getMechanic() == user.getMechanic())"
 *       }
 *     }
 * )
 * @ORM\Entity(repositoryClass=MechanicServiceRepository::class)
 */
class MechanicService
{
    /**
     * @ORM\Id
     * @ORM\GeneratedValue
     * @ORM\Column(type="integer")
     * @Groups({"read", "write"})
     * @ApiProperty(writable=false)
     */
    protected $id;

    /**
     * @var int|null
     * @ORM\Column(type="integer", nullable=true)
     * @Groups({"read", "write"})
     */
    protected $skill;

    /**
     * @var Mechanic
     * @ORM\ManyToOne(targetEntity="Mechanic", inversedBy="services")
     * @ORM\JoinColumn(nullable=false)
     * @Groups({"mechanic_service:read", "mechanic_service:write"})
     */
    protected $mechanic;

    /**
     * @var VehicleTree
     * @ORM\ManyToOne(targetEntity="VehicleTree")
     * @Groups({"read", "mechanic_service:write", "mechanic:write"})
     */
    protected $vehicle;

    /**
     * @var ServiceTree
     * @ORM\ManyToOne(targetEntity="ServiceTree")
     * @Groups({"read", "mechanic_service:write", "mechanic:write"})
     */
    protected $service;

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getSkill(): ?int
    {
        return $this->skill;
    }

    public function setSkill(?int $skill): self
    {
        $this->skill = $skill;
        return $this;
    }

    public function getVehicle(): ?VehicleTree
    {
        return $this->vehicle;
    }

    public function setVehicle(?VehicleTree $vehicle): self
    {
        $this->vehicle = $vehicle;
        return $this;
    }

    public function getService(): ?ServiceTree
    {
        return $this->service;
    }

    public function setService(?ServiceTree $service): self
    {
        $this->service = $service;
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
}
