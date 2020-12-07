<?php

namespace App\Entity;

use ApiPlatform\Core\Annotation\ApiFilter;
use ApiPlatform\Core\Annotation\ApiProperty;
use ApiPlatform\Core\Annotation\ApiResource;
use ApiPlatform\Core\Annotation\ApiSubresource;
use App\Repository\MechanicRepository;
use Doctrine\Common\Collections\ArrayCollection;
use Doctrine\Common\Collections\Collection;
use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Annotation\Groups;
use App\Filter\MechanicDistanceFilter;
use App\Filter\MechanicOrderFilter;
use App\Filter\MechanicVehicleFilter;
use App\Dto;
use Symfony\Component\Serializer\Annotation\MaxDepth;

/**
 * @ApiResource(
 *     normalizationContext={"groups"={"read", "mechanic:read"}},
 *     denormalizationContext={"groups"={"write", "mechanic:write"}},
 *     collectionOperations={
 *         "get",
 *         "post"={
 *             "method"="POST",
 *             "input"=Dto\Input\Mechanic::class
 *         }
 *     },
 *     itemOperations={
 *         "get",
 *         "put"={
 *             "method"="PUT",
 *             "security"="is_granted('ROLE_ADMIN') or object.getUser() == user",
 *             "input"=Dto\Input\Mechanic::class
 *         }
 *     }
 * )
 * @ORM\Entity(repositoryClass=MechanicRepository::class)
 * @ApiFilter(MechanicDistanceFilter::class, properties={"distance"})
 * @ApiFilter(MechanicVehicleFilter::class, properties={"vehicle"})
 * @ApiFilter(MechanicOrderFilter::class, properties={"created_at": "DESC", "distance": "ASC"})
 */
class Mechanic
{
    use Traits\TimestampTrait;

    /**
     * @ORM\Id
     * @ORM\GeneratedValue
     * @ORM\Column(type="integer")
     * @Groups({"read", "write"})
     * @ApiProperty(writable=false)
     */
    protected $id;

    /**
     * @var string
     * @ORM\Column(type="text")
     * @Groups({"mechanic:read", "write"})
     */
    protected $about;

    /**
     * @ORM\Column(type="integer", nullable=true)
     * @Groups({"read", "write"})
     */
    protected $years_of_experience;

    /**
     * @ORM\Column(type="integer", nullable=true)
     * @Groups({"read", "write"})
     */
    protected $working_range;

    /**
     * @ORM\Column(type="float", nullable=true)
     * @Groups({"read", "write"})
     */
    protected $rating;

    /**
     * @var MechanicService[]|Collection
     * @ORM\OneToMany(targetEntity="MechanicService", cascade={"persist", "remove"}, orphanRemoval=true, mappedBy="mechanic")
     * @Groups({"mechanic:read", "mechanic:write"})
     */
    protected $services;

    /**
     * @var User
     * @ORM\OneToOne(targetEntity="User", inversedBy="mechanic")
     * @Groups({"mechanic:read"})
     */
    protected $user;

    /**
     * @var int|null
     * @Groups("read")
     * @ApiProperty()
     */
    public $distance;

    public function __construct()
    {
        $this->services = new ArrayCollection();
    }

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getYearsOfExperience(): ?int
    {
        return $this->years_of_experience;
    }

    public function setYearsOfExperience(?int $years_of_experience): self
    {
        $this->years_of_experience = $years_of_experience;

        return $this;
    }

    public function getWorkingRange(): ?int
    {
        return $this->working_range;
    }

    public function setWorkingRange(?int $working_range): self
    {
        $this->working_range = $working_range;

        return $this;
    }

    public function getRating(): ?float
    {
        return $this->rating;
    }

    public function setRating(?float $rating): self
    {
        $this->rating = $rating;

        return $this;
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

    public function getAbout(): string
    {
        return $this->about;
    }

    public function setAbout(string $about): self
    {
        $this->about = $about;
        return $this;
    }

    public function getServices(): Collection
    {
        return $this->services;
    }

    public function addService(MechanicService $service): self
    {
        if (!$this->services->contains($service)) {
            $this->services->add($service);
            $service->setMechanic($this);
        }
        return $this;
    }

    public function removeService(MechanicService $service): self
    {
        if ($this->services->contains($service)) {
            $this->services->remove($service);
        }
        return $this;
    }



}
